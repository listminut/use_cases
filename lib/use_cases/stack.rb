module UseCases
  class Stack
    attr_reader :steps

    attr_accessor :prev_step_result, :current_step

    def initialize(steps)
      @steps = steps
    end

    def bind(object)
      steps.map! { |step| step.bind(object) }
    end

    def call(initial_value = nil)
      steps.reduce(initial_value) do |prev_result, current_step|
        self.current_step = current_step
        self.prev_step_result = prev_result

        yield
      end
    end

    def in_first_step?
      steps.find_index(current_step).zero?
    end

    def previous_result_empty?
      prev_step_result.nil?
    end

    def previous_step_value
      prev_step_result.value
    end

    def step_names
      steps.map(&:name)
    end

    def find_step(step_name)
      steps.find { |step| step.name == step_name }
    end
  end
end
