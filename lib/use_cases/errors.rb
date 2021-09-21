module UseCases
  class StepArgumentError < ArgumentError; end

  class MissingStepError < NoMethodError; end

  class PreviousStepInvalidReturn < StandardError; end
end
