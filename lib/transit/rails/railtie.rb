require 'rails/railtie'

module Transit
  module Rails
    class Railtie < ::Rails::Railtie
      config.before_initialize do
        require 'transit/rails/renderer'
        require 'action_controller/metal/renderers'

        Mime::Type.register "application/transit+json", :transit
        Mime::Type.register_alias "application/transit+json", :transit_verbose
        Mime::Type.register "application/transit+msgpack", :transit_msgpack

      end

      config.after_initialize do
        ActionController.add_renderer :transit do |obj, options|
          Transit::Rails::Renderer.new(obj, options).render
        end
      end

      initializer "transit.configure_rails_initialization" do |app|
        require 'transit/rails/reader'
        app.middleware.swap("ActionDispatch::ParamsParser",
                            "ActionDispatch::ParamsParser", {
                              Mime::TRANSIT => Transit::Rails::Reader.make_reader(:json),
                              Mime::TRANSIT_VERBOSE => Transit::Rails::Reader.make_reader(:json_verbose),
                              Mime::TRANSIT_MSGPACK => Transit::Rails::Reader.make_reader(:msgpack)
                            })
      end
    end
  end
end
