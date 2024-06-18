class AssignUserToExistingRecipes < ActiveRecord::Migration[6.1]
  def up
    default_user = User.first
    Recipe.update_all(user_id: default_user.id) if default_user
  end

  def down
  end
end
