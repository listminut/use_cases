module UseCases
      module DSL
        def step(name, options = {})
          __steps__ << Steps::Step.new(name, nil, options)
        end

        def map(name, options = {})
          __steps__ << Steps::Map.new(name, nil, options)
        end

        def tee(name, options = {})
          __steps__ << Steps::Tee.new(name, nil, options)
        end

        def try(name, options = {})
          __steps__ << Steps::Try.new(name, nil, options)
        end

        def __steps__
          @__steps__ ||= []
        end

        def subscribe(listeners)
          @listeners = listeners

          if listeners.is_a?(Hash)
            listeners.each do |step_name, listener|
              __steps__.detect { |step| step.name == step_name }.subscribe(listener)
            end
          else
            __steps__.each do |step|
              step.subscribe(listeners)
            end
          end
        end
  end
end
