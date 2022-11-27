require 'app/models/column'
require 'app/aws/dynamodb/columns'
require 'app/aws/dynamodb/advice'

class WorkflowCards

  def initialize(board_id)
    @board_id = board_id
  end

  def columns_by_workflow
    columns.group_by do |column|
      column.kanbanize.workflow_name
    end
  end

  def workflow_cards
    columns_by_workflow.delete_if { |workflow, columns| 
      ignore_any.find { |ignore| workflow.downcase.include?(ignore) }
    }
  end

  def ignore_any
    %w{ initiative epic roadmap }
  end

  def columns
    Gerty::Aws::DynamoDb::Columns.board_columns(@board_id).collect do |column|
      Gerty::Models::Column.new(column)
    end
  end

end