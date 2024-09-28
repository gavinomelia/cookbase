namespace :recipes do
  desc "Update all ingredients to have the correct quantities"
  task update_quantities: :environment do
    Ingredient.find_each do |ingredient|
      # Recalculate the quantity using the defined method
      ingredient.extract_quantity
      
      # Save the ingredient with the updated quantity
      if ingredient.save
        puts "Updated ingredient ID #{ingredient.id} to quantity #{ingredient.quantity}"
      else
        puts "Failed to update ingredient ID #{ingredient.id}: #{ingredient.errors.full_messages.join(', ')}"
      end
    end
  end
end

