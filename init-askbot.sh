source /src/init-vars.sh
function wait_for_db(){
    local t=$1
    if [ -z "${t}" ]; then
        t=1
    fi
    while [[ $t -gt 0 ]] ;do
        local i=5
        while ! $(nc -vz ${ASKBOT_DATABASE_HOST} ${ASKBOT_DATABASE_PORT}); do
            if [[ $i -lt 0 ]]; then
                echo "MAX TIMEOUT REACHED"
                exit 1
            fi
            echo "WAITING FOR DB"
            sleep 5
            let i--
        done;
        let t--
    done;
    sleep 5
}
function initialize(){
    wait_for_db 5;
    askbot-setup --dir-name=. --db-engine=${ASKBOT_DATABASE_ENGINE:-2} \
        --db-name=${ASKBOT_DATABASE_NAME:-db.sqlite} \
        --db-user="${ASKBOT_DATABASE_USER}" \
        --db-password="${ASKBOT_DATABASE_PASSWORD}" \
        --db-host="${ASKBOT_DATABASE_HOST}" \
        --db-port="${ASKBOT_DATABASE_PORT}"

    run_memcached

    echo "Change value for ROOT_URLCONF (before)"
    grep ROOT_URLCONF settings.py

    sed "s/ROOT_URLCONF.*/ROOT_URLCONF = 'urls'/"  settings.py -i

    echo "Change value for ROOT_URLCONF (after)"
    grep ROOT_URLCONF settings.py

    python manage.py collectstatic --noinput
    echo "$? (result collectstatic)"

    python manage.py migrate --noinput
    echo "$? (result migration)"

    if [ -n "${ASKBOT_CREATE_SUPERUSER}" -a -n "${ASKBOT_CREATE_SUPERUSER_PASSWORD}" ]; then
        echo "from django.contrib.auth.models import User; User.objects.create_superuser('${ASKBOT_CREATE_SUPERUSER}','${ASKBOT_CREATE_SUPERUSER_EMAIL}','${ASKBOT_CREATE_SUPERUSER_PASSWORD}')"|python manage.py shell
        echo "$? (result add superuser)"
    fi
}
function run_memcached(){
    local pid=$(pidof memcached)
    if [ -z "$pid" ]; then
        memcached -d -m ${MEMCACHED_MEMORY:-64} -s /tmp/memcached.sock -P /tmp/memcached.pid -u memcache -vv
    fi
}
function run(){
    run_memcached
    #python manage.py migrate --noinput
    python manage.py runserver 0.0.0.0:${ASKBOT_EXPOSE_PORT:-8080}
}

pushd ${PROJECT_DIR:-/site}

if [ ! -d "${PROJECT_DIR}" ];then
    echo "Wrong image"
    exit 1
fi

if [ ! -f "${PROJECT_DIR}/manage.py" ]; then
    initialize;
fi
run;

