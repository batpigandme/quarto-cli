-- astpipeline.lua
-- Copyright (C) 2023 Posit Software, PBC

function quarto_ast_pipeline()
  local function warn_on_stray_triple_colons()
    return {
      Str = function(el)
          if string.match(el.text, ":::(:*)") then 
            local error_message = 
              "\nThe following string was found in the document: " .. el.text .. 
              "\n\nThis usually indicates a problem with a fenced div in the document. Please check the document for errors."
            warn(error_message)
          end
      end
    }
  end
  return {
    { name = "normalize-table-merge-raw-html",
      filter = table_merge_raw_html(),
      traverser = 'jog',
    },

    -- this filter can't be combined with others because it's top-down processing.
    -- unfortunate.
    { name = "normalize-html-table-processing",
      filter = parse_html_tables(),
      traverser = 'jog',
    },

    { name = "normalize-combined-1",
      filter = combineFilters({
          extract_latex_quartomarkdown_commands(),
          forward_cell_subcaps(),
          parse_extended_nodes(),
          code_filename(),
          normalize_fixup_data_uri_image_extension(),
          warn_on_stray_triple_colons(),
      }),
      traverser = 'jog',
    },
    { 
      name = "normalize-combine-2", 
      filter = combineFilters({
          parse_md_in_html_rawblocks(),
          parse_floatreftargets(),
          parse_blockreftargets()
      }),
    },
  }
end
