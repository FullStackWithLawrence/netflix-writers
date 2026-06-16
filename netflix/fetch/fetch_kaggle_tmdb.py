"""
Download and prune Kaggle TMDB datasets.

This script downloads Kaggle TMDB's movie metadata dataset, filters it to retain only relevant information,
and exports the results to CSV files.

https://www.kaggle.com/datasets/asaniczka/full-tmdb-tv-shows-dataset-2023-150k-shows
"""

import os

from kaggle.api.kaggle_api_extended import KaggleApi  # type: ignore[import-untyped]

from .const import DB_DIR

KAGGLE_DIR = os.path.join(DB_DIR, "kaggle", "tmdb-movie-metadata")
DATASET = "asaniczka/full-tmdb-tv-shows-dataset-2023-150k-shows"

api = KaggleApi()


def main():
    """
    Download and unzip the Kaggle TMDB movie metadata dataset.

    This function authenticates with the Kaggle API, downloads the specified dataset,
    and unzips it to the designated directory.

    Raises:
        Exception: If there is an error during authentication or dataset download.
    """
    api.authenticate()
    api.dataset_download_files(DATASET, path=KAGGLE_DIR, unzip=True)
    print("Dataset downloaded successfully.")
    print("-" * 40)


if __name__ == "__main__":

    main()
