## etcdの起動コマンド

```
sudo /bin/sh -c "/usr/local/bin/etcd \
--debug \
--name etcd-1 \
--data-dir /var/lib/etcd \
--quota-backend-bytes 8589934592 \
--auto-compaction-retention 3 \
--listen-client-urls http://192.168.35.101:2379,http://localhost:2379 \
--advertise-client-urls http://192.168.35.101:2379,http://localhost:2379 \
--listen-peer-urls http://192.168.35.101:2380 \
--initial-advertise-peer-urls http://192.168.35.101:2380 \
--initial-cluster 'etcd-1=http://192.168.35.101:2380,etcd-2=http://192.168.35.102:2380,etcd-3=http://192.168.35.103:2380' \
--initial-cluster-token my-etcd-token \
--initial-cluster-state new"
```

```
sudo /bin/sh -c "/usr/local/bin/etcd \
--name etcd-2 \
--data-dir /var/lib/etcd \
--quota-backend-bytes 8589934592 \
--auto-compaction-retention 3 \
--listen-client-urls http://192.168.35.102:2379,http://localhost:2379 \
--advertise-client-urls http://192.168.35.102:2379,http://localhost:2379 \
--listen-peer-urls http://192.168.35.102:2380 \
--initial-advertise-peer-urls http://192.168.35.102:2380 \
--initial-cluster 'etcd-1=http://192.168.35.101:2380,etcd-2=http://192.168.35.102:2380,etcd-3=http://192.168.35.103:2380' \
--initial-cluster-token my-etcd-token \
--initial-cluster-state new"
```

```
sudo /bin/sh -c "/usr/local/bin/etcd \
--name etcd-3 \
--data-dir /var/lib/etcd \
--quota-backend-bytes 8589934592 \
--auto-compaction-retention 3 \
--listen-client-urls http://192.168.35.103:2379,http://localhost:2379 \
--advertise-client-urls http://192.168.35.103:2379,http://localhost:2379 \
--listen-peer-urls http://192.168.35.103:2380 \
--initial-advertise-peer-urls http://192.168.35.103:2380 \
--initial-cluster 'etcd-1=http://192.168.35.101:2380,etcd-2=http://192.168.35.102:2380,etcd-3=http://192.168.35.103:2380' \
--initial-cluster-token my-etcd-token \
--initial-cluster-state new"
```