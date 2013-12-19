# Interface for parsing cmdline-jmxclient output into usable Ruby objects.
# Reads cmdline-jmxclient output and returns a Ruby hash.
#
# Result looks like:
# {
#   'ThreadCount' => '45',
#   'HeapMemoryUsage' => {
#     'committed' => '224...',
#     'init' => '167...',
#     'max' => '259...',
#     'used' => '145...'
#   }
# }
#
module JmxClient

  class Parser

    MULTILINE_FIRST = %r(^
      [0-9/]+\s+    # Matches calendar day, like 12/12/2013.
      [0-9:]+\s+    # Matches timestamp, like 19:11:28.
      [-+0-9]+\s+   # Matches timezone, like +0800 or -0700.
      [a-zA-Z.]+\s+ # Matches Java Bean name, like org.archive.jmx.Client.
      \w+:\s*\n     # Matches Bean attribute, like ThreadCount:.
    )x
    MULTILINE_LAST = /^\s*$/
    MULTILINE_DATA = /^[a-zA-Z]+?: .+$/

    def self.parse(cmd_output)
      self.new.parse(cmd_output)
    end

    def parse(cmd_output)
      parse_all_output(cmd_output)
    end

    private

      def parse_all_output(cmd_output, formatted_output = {})
        if cmd_output.nil? || cmd_output.empty?
          return formatted_output
        elsif bean_not_registered?(cmd_output)
          remaining = drop_first_line(cmd_output)
          return parse_all_output(remaining, formatted_output)
        elsif single_line?(cmd_output)
          remaining, formatted = parse_single_line(cmd_output)
          return parse_all_output(remaining, formatted_output.merge(formatted))
        elsif multiline?(cmd_output)
          remaining, formatted = parse_multiple_lines(cmd_output)
          return parse_all_output(remaining, formatted_output.merge(formatted))
        end
      end

      def bean_not_registered?(output)
        regex = %r(is not a registered bean)
        output.dup.split("\n").shift.chomp.match(regex)
      end

      def single_line?(output)
        regex = %r(^
          [0-9/]+\s+    # Matches calendar day, like 12/12/2013.
          [0-9:]+\s+    # Matches timestamp, like 19:11:28.
          [-+0-9]+\s+   # Matches timezone, like +0800 or -0700.
          [a-zA-Z.]+\s+ # Matches Java Bean name, like org.archive.jmx.Client.
          \w+:\s+       # Matches Bean attribute, like ThreadCount:.
          [0-9a-zA-Z]+$ # Matches Bean attribute value.
        )x
        output.chomp.match(regex)
      end

      def multiline?(output)
        output.match(MULTILINE_FIRST)
      end

      # cmd_output looks like:
      # 12/12/2013 19:11:28 +0000 org.archive.jmx.Client ThreadCount: 45
      #
      # Output:
      # [
      #   <cmd_output, less the first line>
      #   <Ruby hash representation of first line of cmd_output>
      # ]
      #
      def parse_single_line(cmd_output)
        _, _, _, bean, attribute, value = split_single_line(cmd_output)
        [
          drop_first_line(cmd_output),
          { attribute => value.chomp }
        ]
      end

      # cmd_output looks like:
      # 12/12/2013 19:11:28 +0000 org.archive.jmx.Client ThreadCount: 45
      #
      def split_single_line(cmd_output)
        date, time, timezone, bean, attribute, value = cmd_output.split(' ')
        if value.nil?
          [date, time, timezone, bean, attribute[0..-2]]
        else
          [date, time, timezone, bean, attribute[0..-2], value.chomp]
        end
      end

      def drop_first_line(cmd_output)
        cmd_output.split("\n").drop(1).join("\n")
      end

      def first_line?(output_line)
        output_line.match(MULTILINE_FIRST)
      end

      def data_line?(output_line)
        !output_line.match(MULTILINE_FIRST) && output_line.match(MULTILINE_DATA)
      end

      def last_line?(output_line)
        output_line.match(MULTILINE_LAST)
      end

      # cmd_output looks like:
      # 12/12/2013 19:11:19 +0000 org.archive.jmx.Client HeapMemoryUsage:
      # committed: 22429696
      # init: 16777216
      # max: 259522560
      # used: 14500760
      #
      # 12/12/2013 19:11:19 +0000 org.archive.jmx.Client NonHeapMemoryUsage:
      # committed: 25886720
      # init: 12746752
      # max: 100663296
      # used: 25679472
      #
      # Result is like:
      # {
      #   'HeapMemoryUsage' => {
      #     committed: '2242...',
      #     init: '167...',
      #     max: '259...',
      #     used: '145...'
      #   },
      #   'NonHeapMemoryUsage' => {
      #     'committed' => '258...',
      #     'init' => '127...',
      #     'max' => '100...',
      #     'used: '256...'
      #   }
      # }
      #
      # #parse_multiple_lines returns an array:
      # [
      #   <unconsumed portion of cmd_output>,
      #   <formatted output from consumed portion of cmd_output>
      # ]
      #
      def parse_multiple_lines(cmd_output)
        report = {}
        current_attribute = nil

        cmd_output.each_line do |line|
          case
            when first_line?(line)
              _, _, _, bean, attribute, _ = split_single_line(line)
              report[attribute] = {}
              current_attribute = attribute
            when data_line?(line)
              next if current_attribute.nil?
              sub_attribute, value = line.split(' ')
              sub_attribute = sub_attribute[0..-2] # Drop the trailing ':'
              value = value.chomp
              report[current_attribute][sub_attribute] = value
            when last_line?(line)
              current_attribute = nil
          end
        end

        ["", report]
      end

  end

end
