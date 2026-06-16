import argparse
import csv
from pathlib import Path


def get_duplicated_labels(timeseries_csv_path):
    timeseries_csv_path = Path(timeseries_csv_path)

    with timeseries_csv_path.open(newline='', encoding='utf-8') as infile:
        reader = csv.DictReader(infile)
        fieldnames = reader.fieldnames
        if not fieldnames:
            raise ValueError('TIMESERIES_IDS_[network].csv has no headers')
        if 'LABEL' not in fieldnames:
            raise ValueError('TIMESERIES_IDS_[network].csv must contain a LABEL column')

        dup_rows = []
        labels = []
        for row in reader:
            label_value = row['LABEL']
            site_id = row['SITE_ID']
            label_site = f"{row['LABEL']} - {row['SITE_ID']} - {row['PROCESS_LEVEL']}"
            if label_site in labels:
                dup_rows.append(row)
            else:
                labels.append(label_site)

    return dup_rows


def parse_args():
    parser = argparse.ArgumentParser(
        description='Replace LABEL values in TIMESERIES_IDS_NMDB.csv with PARAMETER_NAME from PARAMETER_IDS.csv.'
    )
    parser.add_argument(
        '--timeseries',
        default='TIMESERIES_IDS_COSMOS.csv',
    )

    return parser.parse_args()


def main():
    args = parse_args()
    dup_rows = get_duplicated_labels(args.timeseries)
    for row in dup_rows:
        print(f"{row['TIMESERIES_ID']} - {row['LABEL']}")


if __name__ == '__main__':
    main()
