module TagsHelper
  COLORS = [
    "bg-blue-100 text-blue-800",
    "bg-gray-100 text-gray-800 text-sm font-medium px-3 py-1 rounded",
    "bbg-red-100 text-red-800 text-sm font-medium px-3 py-1 rounded",
"bg-green-100 text-green-800 text-sm font-medium px-3 py-1 rounded",
"bg-yellow-100 text-yellow-800 text-sm font-medium px-3 py-1 rounded",
"bg-indigo-100 text-indigo-800 text-sm font-medium px-3 py-1 rounded",
"bg-purple-100 text-purple-800 text-sm font-medium px-3 py-1 rounded",
"bg-pink-100 text-pink-800 text-sm font-medium px-3 py-1 rounded",
  ]

  # Assign color based on tag name, for consistency across sessions
  def tag_color(tag_name)
    index = tag_name.hash % COLORS.size
    COLORS[index]
  end
end
