# README

## Development

```bash
$ docker-compose up -d
$ docker-compose exec app bundle exec rails db:create
```

### Prettier

```
$ find . -name *.rb | xargs npx prettier --write
```
