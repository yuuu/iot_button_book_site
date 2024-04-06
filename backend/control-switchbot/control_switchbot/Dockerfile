FROM public.ecr.aws/lambda/ruby:3.2

RUN yum -y install gcc make

COPY app.rb Gemfile ./

ENV GEM_HOME=${LAMBDA_TASK_ROOT}
RUN bundle install

# Command can be overwritten by providing a different command in the template directly.
CMD ["app.lambda_handler"]
