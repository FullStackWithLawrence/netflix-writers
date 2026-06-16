"""
Download and prune Kaggle Netflix datasets.

This script downloads Kaggle Netflix's top 10 TV shows and films dataset and
TMDB movie metadata dataset, filters them to retain only relevant information,
and exports the results to CSV files.

https://www.kaggle.com/datasets/dhruvildave/netflix-top-10-tv-shows-and-films
"""

import logging
import os

from kaggle.api.kaggle_api_extended import KaggleApi  # type: ignore[import-untyped]

from .const import DB_DIR

KAGGLE_DIR = os.path.join(DB_DIR, "kaggle", "netflix-top-10-tv-shows-and-films")
DATASET = "dhruvildave/netflix-top-10-tv-shows-and-films"

api = KaggleApi()
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)


def main():
    """
    Download and unzip the Kaggle Netflix top 10 TV shows and films dataset.

    This function authenticates with the Kaggle API, downloads the specified dataset,
    and unzips it to the designated directory.

    Raises:
        Exception: If there is an error during authentication or dataset download.
    """
    api.authenticate()
    api.dataset_download_files(DATASET, path=KAGGLE_DIR, unzip=True)
    logger.info("Dataset downloaded successfully.")
    logger.info("-" * 40)


if __name__ == "__main__":

    main()
