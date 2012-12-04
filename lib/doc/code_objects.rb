module Pod
  module Doc

    # The Doc::CodeObjects are static representation of the documentation
    # data.
    #
    # Every subclass should just be a collection of attributes. The instance
    # variables are serialized to YAML so only the needed information is
    # stored.
    #
    # Markdown and syntax highlighted code is converted immediately to HTML
    # to preserve the performance of middleman live server.
    #
    module CodeObjects

      # The base code object class defines attributes common to the majority of
      # concrete classes.
      #
      # @abstract concrete subclasses must specify their specific attributes.
      #
      class Base

        def initialize
          @children = []
        end

        # @return [String] the name in plain text.
        #
        attr_accessor :name

        # @return [String] the description in HTML.
        #
        attr_accessor :html_description

        def to_s
          name.to_s
        end

        def html_summary
          if html_description
            first_p = html_description.split('</p>').first
            first_p << '</p>' if first_p
          end
        end

        def ruby_representation
          raise "Abstract method not implemented for #{self.class}."
        end

        def ruby_path
           path = parent ? parent.ruby_path + ruby_representation : ruby_representation
           path.gsub(/^::/,'')
        end

        attr_reader :parent

        def parent=(parent)
          parent.children << self
          @parent = parent
        end

        attr_accessor :children

      end
      #--------------------#

      # Represents a generic tag.
      #
      # @return [String] name
      #
      # @return [String] text
      #
      # @return [String] html
      #
      class Param < Struct.new(:name, :types, :html); end

      #--------------------#

      # Represents an example.
      #
      # @return [String] description
      #         The description of the example.
      #
      # @return [String] html
      #         The code of the example in HTML.
      #
      class Example < Struct.new(:description, :html); end

      #--------------------#

      # Provides support for a DSL Namespace.
      #
      class NameSpace < Base

        attr_accessor :full_name

        # @return [Array<Group>]
        #
        attr_accessor :groups

        # @return [Array<DSLAttribute>]
        #
        def meths
          groups.map(&:meths).flatten
        end

        def public_meths
          meths.select{ |m| m.visibility == :public }
        end

        attr_accessor :gem

        def ruby_representation
          "::#{name}"
        end

        def child_name_spaces
          children.select { |c| c.is_a?(NameSpace) }
        end

        attr_accessor :is_class

        attr_accessor :superclass

        attr_accessor :visibility

        attr_accessor :inherited_constants
        attr_accessor :inherited_meths
        attr_accessor :is_exception

        def non_inherited_methods
          meths.reject { |m| m.inherited }
        end

      end

      #--------------------#

      # Doesn't wrap a YARD object.
      #
      class Group < Base

        # @return [Array<DSLAttribute>]
        #
        attr_accessor :meths

      end

      #-----------------------------------------------------------------------#
      # DSL
      #-----------------------------------------------------------------------#

      # Represents an attribute of a DSL
      #
      class DSLAttribute < Base

        # @return [Array<Example>] The list of the examples of the attribute.
        #
        # @return [nil] If there are no examples.
        #
        attr_accessor :examples

        # @return [Array<String>] The list of the default values of the
        #         attribute in HTML (Specification only).
        #
        # @return [nil] If there are no default values.
        #
        attr_accessor :html_default_values

        # @return [Array<String>] The list of the keys accepted by the
        #         attribute in HTML (Specification only).
        #
        # @return [nil] If there are no keys.
        #
        attr_accessor :html_keys

        # @return [Bool] Whether the method is required (Specification only).
        #
        attr_accessor :required
        alias :required? :required

        # @return [Bool] Whether the method is multi-platform (Specification
        #         only).
        #
        attr_accessor :multi_platform
        alias :multi_platform? :multi_platform

      end

      #-----------------------------------------------------------------------#
      # GEM
      #-----------------------------------------------------------------------#

      #
      #
      class Gem < Base

        attr_accessor :version
        attr_accessor :authors
        attr_accessor :name_spaces
        attr_accessor :github_name

        # TODO
        attr_accessor :description

        # @return [NameSpace] all the namespaces that contains methods.
        #
        # Excludes also exceptions
        #
        def namespaces_with_public_methods
            name_spaces.reject do |name_space|
            root = name_space.full_name.split('::').count == 1
            name_space.public_meths.empty? && !root || name_space.is_exception
          end
        end

        def public_name_spaces
          namespaces_with_public_methods.reject { |ns| ns.visibility == :private }
        end


        def methods_with_todos
          name_spaces.map(&:meths).flatten.reject do |m|
            m.html_todos.nil? || m.html_todos.empty? || m.inherited
          end
        end

        def ruby_representation
          ''
        end

      end

      class GemMethod < Base

        # @return [Array<Example>] The list of the examples of the attribute.
        #
        # @return [nil] If there are no examples.
        #
        attr_accessor :examples

        attr_accessor :source_files
        attr_accessor :spec_files

        attr_accessor :parameters
        attr_accessor :signature

        # :class or :instance
        attr_accessor :scope

        # :public, :private, :protected
        attr_accessor :visibility
        attr_accessor :html_source
        attr_accessor :is_attribute
        attr_accessor :is_alias


        attr_accessor :parameters
        attr_accessor :returns

        attr_accessor :html_signature

        attr_accessor :html_todos

        def ruby_representation
          scope == :instance ? "##{name}" : "::#{name}"
        end

        attr_accessor :inherited

        attr_accessor :group

      end

    end
  end
end
