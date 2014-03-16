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
            can [:create, :update, :destroy], Evaluation
            can :create, App
            can [:update, :destroy], App do |app|
                app.user.nil? || user.compareRole > app.user.compareRole || user.id == app.user.id
            end
            can :evaluate, :all
            can :complete, :all
            can :reject, :all
            can :read, :all
            can :rshow, :all

            can :performQueryStatements, :all

        elsif user.role? :Admin
            #Admin
            can [:update, :destroy], User do |u|
               user.compareRole > u.compareRole || user.id == u.id
            end
            can [:create, :update, :destroy], Lo
            can [:create, :update, :destroy], Assignment
            can :create, Evaluation
            can :create, App
            can [:update, :destroy], App do |app|
                app.user.nil? || user.compareRole > app.user.compareRole || user.id == app.user.id
            end
            can :evaluate, :all
            can :complete, :all
            can :reject, :all
            can :read, :all
            can :rshow, :all

        elsif user.role? :Reviewer
            #Reviewers

            can :show, User, :id => user.id
            can :update, User, :id => user.id

            can :rshow, Lo do |lo|
                ["Public","Protected"].include?(lo.scope) or lo.allUsers.include? user
            end
            can :evaluate, Lo do |lo,evmethod|
               (["Public"].include?(lo.scope) or lo.pendingAssignedReviewers.include? user) and (evmethod.nil? or evmethod.allow_multiple_evaluations or Evaluation.where(:lo_id => lo.id, :user_id=> user.id, :evmethod_id => evmethod.id).empty?)
            end

            can :rshow, Assignment, :user_id => user.id
            can :complete, Assignment, :user_id => user.id
            can :reject, Assignment, :user_id => user.id

            can [:show, :rshow], Evaluation, :user_id => user.id
            can :create, Evaluation do |ev|
               ev.lo.nil? or can?(:evaluate, ev.lo, ev.evmethod)
            end
            can :update, Evaluation do |ev|
               ev.user.id == user.id && (ev.assignment.nil? || ev.assignment.deadline.nil? || (ev.assignment.deadline > Time.now))
            end

        elsif user.role? :User
            #Guests
            can :show, User, :id => user.id
            can :update, User, :id => user.id
        else
            #Not loggued users
        end

        #Helpers
        can :rshow, Array do |arr|
            arr.all? { |el| can?(:rshow, el) }
        end

        can :rshow, ActiveRecord::Relation do |arr|
            arr.all? { |el| can?(:rshow, el) }
        end

        can :destroy, Array do |arr|
            arr.all? { |el| can?(:rshow, el) }
        end
        can :destroy, ActiveRecord::Relation do |arr|
            arr.all? { |el| can?(:rshow, el) }
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
