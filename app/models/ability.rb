class Ability
  include CanCan::Ability
 
    def initialize(user)

        user ||= User.new # guest user (not logged in)

        if user.role? :SuperAdmin 
            #SuperAdmin
            can [:update, :destroy], User do |u|
               user.compareRole > u.compareRole || user.id == u.id
            end
            can [:create, :update, :destroy], Lo
            can [:create, :update, :destroy], Assignment
            can :read, :all
            can :rshow, :all
        elsif user.role? :Admin
            #Admin
            can [:update, :destroy], User do |u|
               user.compareRole > u.compareRole || user.id == u.id
            end
            can [:create, :update, :destroy], Lo
            can [:create, :update, :destroy], Assignment
            can :read, :all
            can :rshow, :all
        elsif !user.role.nil?
            #Reviewers and Users
            can :show, User, :id => user.id
            can :update, User, :id => user.id
            can :rshow, Lo do |lo|
                !lo.users.where(:id => user.id).empty?
            end
            can :rshow, Assignment, :user_id => user.id
            can :rshow, Array do |arr|
                arr.all? { |el| can?(:rshow, el) }
            end
        else
            #Not loggued users
        end

        # The first argument to `can` is the action you are giving the user 
        # permission to do.
        # If you pass :manage it will apply to every action. Other common actions
        # here are :read, :create, :update and :destroy.
        #
        # The second argument is the resource the user can perform the action on. 
        # If you pass :all it will apply to every resource. Otherwise pass a Ruby
        # class of the resource.
        #
        # The third argument is an optional hash of conditions to further filter the
        # objects.
        # For example, here the user can only update published articles.
        #
        #   can :update, Article, :published => true
        #

        #:read is an alias for [:show, :index].

        #Example of def initialize(user) method
        # user ||= User.new # guest user (not logged in)
        # if user.role? :super_admin
        #   can :manage, :all
        # elsif user.role? :product_admin
        #   can :manage, [Product, Asset, Issue]
        # elsif user.role? :product_team
        #   can :read, [Product, Asset]
        #   # manage products, assets he owns
        #   can :manage, Product do |product|
        #     product.try(:owner) == user
        #   end
        #   can :manage, Asset do |asset|
        #     asset.assetable.try(:owner) == user
        #   end
        # end

        # See the wiki for details:
        # https://github.com/ryanb/cancan/wiki/Defining-Abilities
    end

end
