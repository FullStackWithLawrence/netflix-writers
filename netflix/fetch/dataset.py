"""Unified dataset builder for Netflix + TMDB + IMDb."""

import json
import re
from pathlib import Path

import pandas as pd
from rapidfuzz.distance import JaroWinkler

from .const import DB_DIR

KAGGLE_PATH = Path(DB_DIR) / "kaggle"
IMDB_PATH = Path(DB_DIR) / "imdb"

IMDB_TITLES_BASICS_FILE = IMDB_PATH / "title.basics.tsv.gz"
IMDB_TITLE_RATINGS_FILE = IMDB_PATH / "title.ratings.tsv.gz"

TMDB_TV_DATA_FILE = KAGGLE_PATH / "tmdb-movie-metadata" / "TMDB_tv_dataset_v3.csv"
NETFLIX_FILE = KAGGLE_PATH / "netflix-top-10-tv-shows-and-films" / "all-weeks-global.csv"


# =========================================================
# CLEANING
# =========================================================


def _clean(s) -> str:
    if s is None or (isinstance(s, float) and pd.isna(s)):
        return ""

    s = str(s).lower()
    s = re.sub(r"\band\b", " ", s)
    s = re.sub(r"[^a-z0-9 ]", " ", s)
    s = re.sub(r"\s+", " ", s).strip()
    return s


def get_blocking_key(title: str) -> str:
    cleaned = _clean(title)
    if not cleaned:
        return "empty"

    stop_words = {"the", "a", "an", "of", "in", "to", "for", "with", "on", "at"}
    tokens = [t for t in cleaned.split() if t not in stop_words] or cleaned.split()

    parts = sorted([t[:2] for t in tokens[:3]])
    return "_".join(parts) if parts else "empty"


# =========================================================
# SAFE JSON CASTING (FIXED)
# =========================================================


def safe_cast(x):
    """
    Always returns a list safely, even if input is:

    - NaN
    - list
    - dict
    - malformed JSON string
    - numpy array
    """
    if x is None:
        return []

    # already list-like
    if isinstance(x, list):
        return x

    if isinstance(x, tuple):
        return list(x)

    # pandas NaN safe check
    try:
        if pd.isna(x):
            return []
    except Exception:
        pass

    if isinstance(x, str):
        try:
            parsed = json.loads(x)
            if isinstance(parsed, list):
                return [c.get("name") for c in parsed if isinstance(c, dict) and "name" in c]
            return []
        except Exception:
            return []

    return []


# =========================================================
# LOAD
# =========================================================


def load_data():
    return (
        pd.read_csv(NETFLIX_FILE),
        pd.read_csv(TMDB_TV_DATA_FILE),
        pd.read_csv(IMDB_TITLES_BASICS_FILE, sep="\t", low_memory=False),
        pd.read_csv(IMDB_TITLE_RATINGS_FILE, sep="\t", low_memory=False),
    )


# =========================================================
# NETFLIX
# =========================================================


def build_netflix(df):
    df = df.copy()

    df["week_date"] = pd.to_datetime(df["week"], errors="coerce")
    df["year_hint"] = df["week_date"].dt.year

    df["key"] = df["show_title"].apply(get_blocking_key)
    df["clean_title"] = df["show_title"].apply(_clean)

    return df.groupby("key", as_index=False).agg(
        viewing_hours=("weekly_hours_viewed", "sum"),
        weeks=("cumulative_weeks_in_top_10", "max"),
        year_hint=("year_hint", "min"),
        netflix_title=("show_title", "first"),
        clean_netflix_title=("clean_title", "first"),
    )


# =========================================================
# TMDB (FIXED FOR YOUR NEW SCHEMA)
# =========================================================


def build_tmdb(df):
    tmdb = df.copy()

    # NEW DATASET FIX:
    tmdb["title"] = tmdb.get("name", tmdb.get("original_name", ""))

    tmdb["year"] = pd.to_datetime(tmdb.get("first_air_date"), errors="coerce").dt.year
    tmdb["clean_title"] = tmdb["title"].apply(_clean)

    tmdb["key"] = tmdb["title"].apply(get_blocking_key)

    return tmdb[
        [
            "key",
            "title",
            "clean_title",
            "year",
            "popularity",
            "vote_average",
            "vote_count",
        ]
    ]


# =========================================================
# MATCHING
# =========================================================


def match(netflix, tmdb, score_threshold=0.85):
    candidates = tmdb.merge(netflix, on="key", how="inner")

    if candidates.empty:
        return pd.DataFrame()

    # year filter (safe)
    valid_years = candidates["year"].isna() | (candidates["year_hint"] >= (candidates["year"] - 1))
    candidates = candidates[valid_years]

    if candidates.empty:
        return pd.DataFrame()

    candidates["match_score"] = candidates.apply(
        lambda r: JaroWinkler.normalized_similarity(r["clean_title"], r["clean_netflix_title"]),
        axis=1,
    )

    matches = candidates[candidates["match_score"] >= score_threshold]

    if matches.empty:
        return pd.DataFrame()

    matches = matches.sort_values(
        ["match_score", "popularity"],
        ascending=[False, False],
    )

    return matches.drop_duplicates(subset=["netflix_title"], keep="first")


# =========================================================
# PIPELINE
# =========================================================


def create_dataset():
    netflix_raw, tmdb_raw, imdb_basics, imdb_ratings = load_data()

    netflix = build_netflix(netflix_raw)
    tmdb = build_tmdb(tmdb_raw)

    print("TMDB rows:", len(tmdb))
    print("Netflix rows:", len(netflix))

    base = match(netflix, tmdb)

    print("Matches:", len(base))
    print("Match rate:", len(base) / len(netflix) if len(netflix) else 0)

    return base


def main():
    df = create_dataset()
    if not df.empty:
        print(df.head())


if __name__ == "__main__":
    main()
