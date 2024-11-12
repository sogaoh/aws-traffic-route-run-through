FROM public.ecr.aws/aws-cli/aws-cli:latest
COPY ./container/check_login.sh .
RUN chmod 700 check_login.sh
RUN yum update && yum install -y \
    curl \
    wget \
    && yum clean all
ENV SLEEP_SECONDS=900
ENTRYPOINT ["sh", "-c", "./check_login.sh $SLEEP_SECONDS"]
