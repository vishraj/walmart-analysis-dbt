import boto3

# create S3 client
s3 = boto3.client('s3')

# set the destination bucket
s3_bucket = 'walmart-raw-source-vr'

local_files = ['department.csv', 'fact.csv', 'stores.csv']
for file in local_files:
	s3_key = file

	# Upload the file to S3
	s3.upload_file(file, s3_bucket, s3_key)
	print(f'Uploaded file {file} to s3 bucket {s3_bucket}')




