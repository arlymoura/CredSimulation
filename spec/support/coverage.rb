require "simplecov"

SimpleCov.start do
  enable_coverage :branch

  add_filter "/app/views/"
  add_filter "/app/blueprints/"
  add_filter "/config/"
  add_filter "/lib/"
  add_filter "/spec/"

  add_group "Controllers", "app/controllers"
  add_group "Models", "app/models"
  add_group "Services", "app/services"
end
