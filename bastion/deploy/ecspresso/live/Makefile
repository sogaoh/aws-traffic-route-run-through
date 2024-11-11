.PHONY: verify status diff tasks trace exec exec-pf dry-deploy deploy rollback dry-rollback soft-rollback appspec scale1 scale0 scale revs dereg

help:
	cat Makefile

CONF_OPT := --config ecspresso.yaml
DEPLOY_OPT :=
#NO_WAIT_OPT := --no-wait
WAIT_OPT :=
APPSPEC_OPT := current
SCALE_TASKS := 1
KEEPS := 3

REMOTE_DB_HOST :=
REMOTE_DB_PORT := 3306
LOCAL_DB_PORT := 13306

#SECRETMGR_ARN := "arn:aws:secretsmanager:ap-northeast-1:XXXXXXXXXXXX:secret:rds!db-XXXXXXXX-XXXX0-XXXX-XXXX-XXXXXXXXXXXX-XXXXXX"


verify:
	#SECRETMANAGER_ARN=$(SECRETMGR_ARN) ecspresso $(CONF_OPT) verify
	ecspresso $(CONF_OPT) verify

status:
	ecspresso $(CONF_OPT) status

diff:
	ecspresso $(CONF_OPT) diff

tasks:
	ecspresso $(CONF_OPT) tasks

trace:
	ecspresso $(CONF_OPT) tasks --trace

exec:
	ecspresso $(CONF_OPT) exec --command bash

exec-pf-db:
	ecspresso $(CONF_OPT) exec --port-forward -L $(LOCAL_DB_PORT):$(REMOTE_DB_HOST):$(REMOTE_DB_PORT)

run:
	ecspresso $(CONF_OPT) run

dry-deploy:
	ecspresso $(CONF_OPT) deploy --dry-run $(DEPLOY_OPT)

deploy:
	ecspresso $(CONF_OPT) deploy $(DEPLOY_OPT) $(WAIT_OPT)

rollback:
	ecspresso $(CONF_OPT) rollback --deregister-task-definition

dry-rollback:
	ecspresso $(CONF_OPT) rollback --dry-run

soft-rollback:
	ecspresso $(CONF_OPT) rollback

appspec:
	ecspresso $(CONF_OPT) appspec --task-definition=$(APPSPEC_OPT)

scale1:
	ecspresso $(CONF_OPT) scale --tasks=1
scale0:
	ecspresso $(CONF_OPT) scale --tasks=0
scale:
	ecspresso $(CONF_OPT) scale --tasks=$(SCALE_TASKS)

revs:
	ecspresso $(CONF_OPT) revisions

dereg:
	ecspresso $(CONF_OPT) deregister --keeps=$(KEEPS) --force

#db-migrate:
#	ecspresso $(CONF_OPT) run --debug --overrides-file=./overrides/db-migrate.json
