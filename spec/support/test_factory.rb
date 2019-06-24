# frozen_string_literal: true

module TestFactory
  def create(name, opts = {})
    Fabricate(name, opts)
  end

  def build(name, opts = {})
    Fabricate.build name, opts
  end

  def attributes_for(name, opts = {})
    Fabricate.attributes_for(name, opts)
  end
end
