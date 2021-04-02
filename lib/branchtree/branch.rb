
module Branchtree

  # Represents a git branch in the current repository.
  class Branch
    include Branchtree::Context

    # Recursively load a Branch instance and its children, if any, from deserialized YAML.
    def self.load(node, parent)
      new(node.fetch("branch"), parent, node.fetch("rebase", false)).tap do |branch|
        node.fetch("children", []).each do |child_node|
          branch.children << load(child_node, branch)
        end
        branch.children.freeze
      end
    end

    attr_reader :name, :children
    attr_accessor :info

    def initialize(name, parent, rebase)
      @name = name
      @parent = parent
      @rebase = rebase
      @children = []
      @info = NullInfo.new(self)
    end

    def root?
      @parent.nil?
    end

    def rebase?
      @rebase
    end

    # Return the String name of the ref that this branch is based on. New changes to this parent ref will
    # be merged in on "apply".
    def parent_branch_name
      return @parent.name if @parent

      if cmd.run!("git", "rev-parse", "--verify", "--quiet", "refs/heads/main").success?
        "main"
      else
        "master"
      end
    end

    # Return the full git ref name of this branch.
    def full_ref
      "refs/heads/#{name}"
    end

    # Checkout this branch with git
    def checkout
      qcmd.run("git", "checkout", name)
    end

    def merge_parent
      qcmd.run!("git", "merge", parent_branch_name)
    end

    def rebase_parent
      qcmd.run!("git", "rebase", parent_branch_name)
    end

    class NullInfo
      def initialize(branch)
        @branch = branch
      end

      def empty?
        true
      end

      def valid?
        true
      end

      def ahead_of_parent
        0
      end

      def behind_parent
        0
      end

      def has_upstream?
        false
      end

      def ahead_of_upstream
        0
      end

      def behind_upstream
        0
      end

      def populate
        # Are we valid?
        valid_result = @branch.cmd.run!("git", "rev-parse", "--verify", "--quiet", @branch.full_ref)
        unless valid_result.success?
          return @branch.info = InvalidInfo.new(@branch)
        end

        # Count ahead-behind from parent
        ahead_behind_parent = @branch.cmd.run(
          "git", "rev-list", "--left-right", "--count", "refs/heads/#{@branch.parent_branch_name}...#{@branch.full_ref}",
        ).out.chomp
        parent_behind, parent_ahead = ahead_behind_parent.split(/\t/, 2).map(&:to_i)

        # Idenfity if we have an upstream
        upstream_ref, upstream_behind, upstream_ahead = "", 0, 0
        upstream_result = @branch.cmd.run!(
          "git", "rev-parse", "--symbolic-full-name", "#{@branch.full_ref}@{u}",
        )
        if upstream_result.success?
          upstream_ref = upstream_result.out.chomp

          ahead_behind_upstream = @branch.cmd.run(
            "git", "rev-list", "--left-right", "--count", "#{upstream_ref}...#{@branch.full_ref}",
          ).out.chomp
          upstream_behind, upstream_ahead = ahead_behind_upstream.split(/\t/, 2).map(&:to_i)
        end

        @branch.info = Info.new(
          ahead_of_parent: parent_ahead,
          behind_parent: parent_behind,
          upstream: upstream_ref,
          ahead_of_upstream: upstream_ahead,
          behind_upstream: upstream_behind,
        )
      end
    end

    class InvalidInfo < NullInfo
      def empty?
        false
      end

      def valid?
        false
      end

      def populate
        self
      end
    end

    class Info
      def initialize(ahead_of_parent:, behind_parent:, upstream:, ahead_of_upstream:, behind_upstream:)
        @ahead_of_parent = ahead_of_parent
        @behind_parent = behind_parent
        @upstream = upstream
        @ahead_of_upstream = ahead_of_upstream
        @behind_upstream = behind_upstream
      end

      attr_reader :ahead_of_parent, :behind_parent, :upstream, :ahead_of_upstream, :behind_upstream

      def empty?
        false
      end

      def valid?
        true
      end

      def has_upstream?
        @upstream != ""
      end

      def populate
        self
      end
    end
  end

end