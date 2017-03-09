require "json"

module Unicoder
  # Include after Builder
  module MultiDimensionalArrayBuilder
    def initialize_index
      @index = []
    end

    def assign_codepoint(codepoint, value, index = @index)
      plane         = codepoint    / 0x10000
      plane_offset  = codepoint    % 0x10000
      row           = plane_offset / 0x1000
      row_offset    = plane_offset % 0x1000
      byte          = row_offset   / 0x100
      byte_offset   = row_offset   % 0x100
      nibble        = byte_offset  / 0x10
      nibble_offset = byte_offset  % 0x10

      index[plane] ||= []
      index[plane][row] ||= []
      index[plane][row][byte] ||= []
      index[plane][row][byte][nibble] ||= []
      index[plane][row][byte][nibble][nibble_offset] = value
    end

    def compress!(index = @index)
      index.map!{ |plane|
        if !plane.is_a?(Array)
          plane
        elsif plane.flatten.uniq.size == 1
          plane[0]
        else
          plane.map!{ |row|
            if !row.is_a?(Array)
              row
            elsif row.flatten.uniq.size == 1
              row[0]
            else
              row.map!{ |byte|
                if !byte.is_a?(Array)
                  byte
                elsif byte.uniq.size == 1
                  byte[0]
                else
                  byte.map! { |nibble|
                    if !nibble.is_a?(Array)
                      nibble
                    elsif nibble.uniq.size == 1
                      nibble[0]
                    else
                      nibble
                    end
                  }
                end
              }
            end
          }
        end
      }
    end

    def remove_trailing_nils!(index = @index)
      index.each{ |plane|
        if plane.is_a?(Array)
          plane.pop while plane[-1] == nil
          plane.each{ |row|
            if row.is_a?(Array)
            row.pop while row[-1] == nil
            row.each{ |byte|
              if byte.is_a?(Array)
                byte.pop while byte[-1] == nil
                byte.each{ |nibble|
                  if nibble.is_a?(Array)
                    nibble.pop while nibble[-1] == nil
                  end
                }
              end
            }
            end
        }
        end
      }
    end
  end
end
