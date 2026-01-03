FROM p5-base

CMD ["/spark-3.5.5-bin-hadoop3/sbin/start-master.sh", "&&", "sleep", "infinity"]
