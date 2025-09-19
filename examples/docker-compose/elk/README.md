# elk

```bash
docker-compose up -d

# Wait for about 30 seconds

docker-compose exec filebeat \
    filebeat setup \
    -strict.perms=false \
    -E setup.kibana.host=kibana:5601 \
    -E output.elasticsearch.hosts=["elasticsearch:9200"]

docker-compose exec metricbeat \
    metricbeat setup \
    -strict.perms=false \
    -E setup.kibana.host=kibana:5601 \
    -E output.elasticsearch.hosts=["elasticsearch:9200"]
```

Then visit http://localhost:5601/.

## Links

- For a complete _Kibana_ demo, see [demo.elastic.co](https://demo.elastic.co/)
- [How to scrape Prometheus metrics](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-metricset-prometheus-collector.html)
- [Creating Alerts in Kibana Elasticsearch](https://www.youtube.com/watch?v=mKobmmDmD0Q)
- https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-compose-file
- https://github.com/elastic/elasticsearch/tree/master/docs/reference/setup/install/docker
