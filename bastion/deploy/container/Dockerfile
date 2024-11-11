FROM public.ecr.aws/amazonlinux/amazonlinux:2023
COPY ./container/check_login.sh .
RUN chmod 700 check_login.sh
RUN dnf update -y && \
    dnf install -y procps
ENV SLEEP_SECONDS=900
ENTRYPOINT ["sh", "-c", "./check_login.sh $SLEEP_SECONDS"]
