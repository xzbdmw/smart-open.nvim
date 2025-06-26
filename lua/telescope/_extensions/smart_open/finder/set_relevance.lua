--- Configure set_relevance function with a matching_algorithm
---@param options table
--   matching_algorithm string: fzf or fzy
--   native_fzy_path string: the path to the native fzy (only applicable if fzy is selected)
--   weights table: the current weight values
return function(options)
  local matching_algorithm = options.matching_algorithm
  local weights = options.weights

  matching_algorithm = matching_algorithm or "fzy"
  assert(matching_algorithm == "fzy" or matching_algorithm == "fzf", "Matching algorithm must be fzf or fzy")

  local prompt_matcher = require("smart-open.matching.algorithms." .. matching_algorithm)
  prompt_matcher.init(options)

  local update_match_scores = function(prompt, entry)
    local path_prop = "path_" .. matching_algorithm

    local path_score = prompt_matcher.score(prompt, entry.path, entry)
    if path_score == 0 then
      return 0
    end
    entry.scores = entry.scores or {}
    entry.scores[path_prop] = weights[path_prop] * path_score

    local vn_prop = "virtual_name_" .. matching_algorithm
    local vn_score = prompt_matcher.score(prompt, entry.virtual_name, entry)
    entry.scores[vn_prop] = weights[vn_prop] * vn_score

    -- Apply exact filename match bonus based on percentage match
    local exact_bonus = 0
    -- Extract filename without extension from virtual_name
    local filename_without_ext = entry.virtual_name:match("([^/\\]+)%.[^.]*$")
      or entry.virtual_name:match("([^/\\]+)$")
      or entry.virtual_name
    local trimmed_prompt = vim.trim(prompt:lower())
    if
      (("'" .. filename_without_ext):lower():find(trimmed_prompt, 1, true) and #trimmed_prompt > 0)
      or (filename_without_ext:lower():find(trimmed_prompt, 1, true) and #trimmed_prompt > 0)
    then
      -- Calculate percentage: prompt length / filename length
      local match_percentage = #trimmed_prompt / #filename_without_ext
      exact_bonus = (weights.exact_filename_bonus or 0) * match_percentage
      entry.scores.exact_filename_bonus = exact_bonus
    end

    return entry.scores[vn_prop] + entry.scores[path_prop] + exact_bonus
  end

  local M = {}

  --- Assign a final relevance to the entry, given the filter text
  --- additionally, store the prompt-match scores on each entry so weights can be recalculated
  ---@param prompt string: The filter text
  ---@param entry table: The entry will be modified in-place
  function M.run(prompt, entry)
    local match_score = update_match_scores(prompt, entry)

    entry.relevance = entry.base_score + match_score
    entry.ordinal = entry.relevance
    entry.hide = match_score <= 0
  end

  function M.destroy()
    if prompt_matcher.destroy then
      prompt_matcher.destroy()
    end
  end

  return M
end
