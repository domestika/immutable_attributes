require 'test/unit'
require 'rubygems'
require 'activerecord'
require File.join(File.dirname(__FILE__), '..', 'lib', 'immutable_attributes')

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :dbfile  => ":memory:"
)
ActiveRecord::Schema.define do
  create_table :records do |table|
    table.column :name, :string
    table.column :body, :string
  end
  
  create_table :validated_records do |table|
    table.column :name, :string
    table.column :type, :string
  end
end

class Record < ActiveRecord::Base
  attr_immutable :name
end

class SubRecord < Record
end

class ValidatedRecord < ActiveRecord::Base
  validates_immutable :name
end

class ValidatedSubRecord < ValidatedRecord
end

class ImmutableAttributesTest < Test::Unit::TestCase

  def test_immutable_attribute_can_be_set
    assert Record.new(:name => 'record name')
  end

  def test_immutable_attribute_cannot_be_changed
    record = Record.create!(:name => 'record name')
    assert_raises(ActiveRecord::ImmutableAttributeError) { record.update_attributes(:name => 'new name') }
  end
  
  def test_immutable_attribute_cannot_be_changed_on_subclass
    record = SubRecord.create!(:name => 'record name')
    assert_raises(ActiveRecord::ImmutableAttributeError) { record.update_attributes(:name => 'new name') }
  end
  
  def test_changing_immutable_attribute_makes_record_invalid
    validated_record = ValidatedRecord.create!(:name => 'validated record')
    validated_record.update_attributes(:name => 'new name')
    assert validated_record.errors.on(:name), "Record should be invalid"
  end
  
  def test_validation_should_be_inherited_by_subclass
    validated_record = ValidatedSubRecord.create!(:name => 'validated record')
    validated_record.update_attributes(:name => 'new name')
    assert validated_record.errors.on(:name), "Record should be invalid"
  end
end