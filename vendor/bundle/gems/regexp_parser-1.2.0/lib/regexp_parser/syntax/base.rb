require 'set'

module Regexp::Syntax
  class NotImplementedError < SyntaxError
    def initialize(syntax, type, token)
      super "#{syntax.class.name} does not implement: [#{type}:#{token}]"
    end
  end

  # A lookup map of supported types and tokens in a given syntax
  class Base
    include Regexp::Syntax::Token

    def initialize
      @implements = {}

      implements Token::Literal::Type,   Token::Literal::All
      implements Token::FreeSpace::Type, Token::FreeSpace::All
    end

    def implementations(type)
      @implements[type] ||= Set.new
    end

    def implements(type, tokens)
      implementations(type).merge(Array(tokens))
    end

    def excludes(type, tokens)
      implementations(type).subtract(Array(tokens))
    end

    def implements?(type, token)
      implementations(type).include?(token)
    end
    alias :check? :implements?

    def implements!(type, token)
      raise NotImplementedError.new(self, type, token) unless
        implements?(type, token)
    end
    alias :check! :implements!

    def normalize(type, token)
      case type
      when :group
        normalize_group(type, token)
      when :backref
        normalize_backref(type, token)
      else
        [type, token]
      end
    end

    def normalize_group(type, token)
      case token
      when :named_ab, :named_sq
        [:group, :named]
      else
        [type, token]
      end
    end

    def normalize_backref(type, token)
      case token
      when :name_ref_ab, :name_ref_sq
        [:backref, :name_ref]
      when :name_call_ab, :name_call_sq
        [:backref, :name_call]
      when :name_recursion_ref_ab, :name_recursion_ref_sq
        [:backref, :name_recursion_ref]
      when :number_ref_ab, :number_ref_sq
        [:backref, :number_ref]
      when :number_call_ab, :number_call_sq
        [:backref, :number_call]
      when :number_rel_ref_ab, :number_rel_ref_sq
        [:backref, :number_rel_ref]
      when :number_rel_call_ab, :number_rel_call_sq
        [:backref, :number_rel_call]
      when :number_recursion_ref_ab, :number_recursion_ref_sq
        [:backref, :number_recursion_ref]
      else
        [type, token]
      end
    end

    def self.inspect
      "#{super} (feature set of #{ancestors[1].to_s.split('::').last})"
    end
  end
end
