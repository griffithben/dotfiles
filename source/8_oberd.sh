#!/bin/bash

source ~/.env.local

function dump_schema_to_sql {
  local container=$1
  local schema=$2
  local filename=$3
  mysqldump_container $container --add-drop-table --skip-dump-date --skip-comments \
    --ignore-table=$schema.StudyStartDates -d \
    $schema | awk '{ if ( NR > 1  ) { print } }' | sed 's/ AUTO_INCREMENT=[0-9]*\b//' > $filename
}

function oberd_update_test_schema {
  cd "$OBERD_DIR"
  dump_schema_to_sql oberd_db_1 medadatonline_demo tests/current_schema.sql
  dump_schema_to_sql oberd_db_1 demo_InstitutionURS tests/current_institution_schema.sql
}

function oberd_import_test_schema {
  cd "$OBERD_DIR"
  import_database oberd_db_1 medadatonline_test tests/current_schema.sql
  import_database oberd_db_1 test_InstitutionFixture tests/current_institution_schema.sql
  import_database oberd_db_1 OBERDDevice_test tests/current_device_schema.sql
}

function oberd_test {
  docker exec  oberd_web_1 /bin/bash -c "cd /var/www/tests && php lib/phpunit/bin/phpunit --testsuite=$1"
}

function oberd_browser {
  docker exec oberd_web_1 /bin/bash -c 'php -d error_reporting="E_ALL&~E_WARNING&~E_NOTICE&~E_STRICT" tests/lib/phpunit/bin/paratest -p 2 -f --phpunit=tests/lib/phpunit/bin/phpunit -c tests/browser/phpunit.xml --testsuite="browser"'
}
function oberd_browser_single {
  docker exec oberd_web_1 /bin/bash -c 'php -d error_reporting="E_ALL&~E_WARNING&~E_NOTICE&~E_STRICT" tests/lib/phpunit/bin/phpunit -c tests/browser/phpunit.xml --testsuite="browser"'
}