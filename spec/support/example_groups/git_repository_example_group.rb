# frozen_string_literal: true

require 'active_support/concern'

module GitRepositoryExampleGroup
  module Hooks
    extend ActiveSupport::Concern

    included do
      git_subject_proc = -> { @git_subject_block }
      before(:all) do
        @dir = Dir.mktmpdir
        Dir.chdir(@dir) do
          git_subject_block = git_subject_proc.call
          git = instance_eval(&git_subject_block)
          raise 'Block did not return a Wrapper instance!' unless git.is_a?(Bringit::Wrapper)
          @git_path = git.path
        end
      end
      after(:all) { Pathname.new(@dir).rmtree }
      subject { Bringit::Wrapper.new(@git_path) }
    end
  end

  module ExampleGroupMethods
    # This method sets the subject to a new instance of Bringit::Wrapper that is created with
    # the block. The given block must return an instance of Bringit::Wrapper.
    def git_subject(&block)
      @git_subject_block = block
    end
  end

  RSpec.configure do |config|
    config.include self::Hooks, git_repository: true
    config.extend self::ExampleGroupMethods, git_repository: true
  end
end
