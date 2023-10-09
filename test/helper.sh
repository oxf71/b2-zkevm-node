set -x

shopt -s expand_aliases
alias geth="docker-compose exec -T zkevm-mock-l1-network geth"

run() {
    make restart
    make stop-explorer
    make run-explorer
}
containers() {
    exec >"$FUNCNAME.log" 2>&1
    # docker-compose ps --all --format json >tmp-containers.json
    docker-compose ps --all
}

onlyProbeL1() {
    exec > "$FUNCNAME.log" 2>&1

    # docker-compose --help
    # docker-compose down -v zkevm-mock-l1-network
    # docker-compose up -d zkevm-mock-l1-network
    # return

    # docker-compose exec -T zkevm-mock-l1-network uname -a
    geth --help
    geth version
    geth license
    return

    # docker-compose logs --help
    docker-compose logs \
        --no-log-prefix \
        --no-color \
        zkevm-mock-l1-network
    # --tail 10 \
}

collectionLog() {
    for name in \
        zkevm-approve \
        zkevm-sync \
        zkevm-eth-tx-manager \
        zkevm-sequencer \
        zkevm-sequence-sender \
        zkevm-l2gaspricer \
        zkevm-aggregator \
        zkevm-json-rpc \
        zkevm-mock-l1-network \
        zkevm-prover; do
        docker-compose logs \
            --no-log-prefix \
            --no-color \
            $name >$name.log
    done
}

alias psql="docker exec -interactive --tty zkevm-state-db psql "

init() {
    exec >"$FUNCNAME.log" 2>&1
    # docker exec --help
    psql --help
    return
    go version
    docker ps
    return
}

probe() {
    exec >"$FUNCNAME.log" 2>&1
    # grep -irE 'STATEDB.*:|POOLDB.*:|EVENTDB.*:|NETWORK' Makefile

    export DATABASE_URL="postgres://l1_explorer_user:l1_explorer_password@192.168.50.127:5436/l1_explorer_db?sslmode=disable"
    psql --echo-all $DATABASE_URL --file=zkevm-l1.sql
    # return
    export DATABASE_URL="postgres://pool_user:pool_password@192.168.50.127:5433/pool_db?sslmode=disable"
    psql --echo-all $DATABASE_URL --file=zkevm-pool.sql

    export DATABASE_URL="postgres://state_user:state_password@192.168.50.127:5432/state_db?sslmode=disable"
    psql --echo-all $DATABASE_URL --file=zkevm-state.sql

    export DATABASE_URL="postgres://event_user:event_password@192.168.50.127:5435/event_db?sslmode=disable"
    psql --echo-all $DATABASE_URL --file=zkevm-event.sql
    # psql --echo-all $DATABASE_URL --file=zkevm-event.sql --output=zkevm-event.log
    # psql --echo-hidden $DATABASE_URL --file=zkevm-event.sql --output=zkevm-event.log
}

$@
