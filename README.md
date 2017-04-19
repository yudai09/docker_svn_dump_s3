#docker_svn_dump_s3
====

##Overview
dockerでSubversionのdumpファイルをS3にバックアップするツール

* 以下のプログラムのSVN版
[mysql-backup-s3](https://github.com/schickling/dockerfiles/tree/master/mysql-backup-s3)

* go-cronによる定期バックアップ対応
* マルチホスト未対応

## Install
```sh
$ git clone https://github.com/yudai09/docker_svn_dump_s3.git
$ docker build -f ./Dockerfile -t svn-backup-s3 .
```

## Usage

```sh
$ docker run -v /host:/container -e BACKUP_DIR=/container -e S3_ACCESS_KEY_ID=key -e S3_SECRET_ACCESS_KEY=secret -e S3_BUCKET=my-bucket -e S3_PREFIX=backup -e S3_ENDPOINT=cloud-endpoint svn-backup-s3
```

## Environment variables

- `S3_ACCESS_KEY_ID` your AWS access key *required*
- `S3_SECRET_ACCESS_KEY` your AWS secret key *required*
- `S3_BUCKET` your AWS S3 bucket path *required*
- `S3_PREFIX` path prefix in your bucket (default: 'backup')
- `S3_REGION` the AWS S3 bucket region (default: us-west-1)
- `S3_ENDPOINT` the AWS Endpoint URL, for S3 Compliant APIs such as [minio](https://minio.io) (default: none)
- `S3_S3V4` set to `yes` to enable AWS Signature Version 4, required for [minio](https://minio.io) servers (default: no)
- `SCHEDULE` backup schedule time, see explainatons below

### 定期バックアップ

起動コマンドに、以下のような環境変数を追加することで定期バックアップをおこなうことができる。
```sh
-e SCHEDULE="@daily"
```
スケジューリングの設定値は以下を参照
[here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).

