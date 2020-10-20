echo 'host  replication     postgres            172.17.0.0/24       trust' >> ./data/pg_hba.conf
echo 'host  all             all                 172.17.0.0/24       trust' >> ./data/pg_hba.conf