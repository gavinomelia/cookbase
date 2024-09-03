namespace :images do
  desc "Preprocess images to generate variants"
  task preprocess: :environment do
    Recipe.find_each do |recipe|
      begin
        if recipe.image.attached?
          # Access and generate the variants, ensuring they're processed and stored
          recipe.processed_image_variants.each_value(&:processed)

          puts "Processed variants for Recipe ##{recipe.id}"
        else
          puts "No image attached for Recipe ##{recipe.id}"
        end
      rescue => e
        puts "Failed to process Recipe ##{recipe.id}: #{e.message}"
      end
    end
  end
end

