module ConstructedsHelper
  def klass_collection_for_select
    collection = [["- #{t('shared.matchlist.any_class')} -", '']]
    Klass.all.map { |k| collection << [k.name, k.id ]}
    
    collection
  end
  
  def items_per_page_for_select
    [10, 20, 50, 100].map { |i| ["#{i} #{t('.per_page')}", i] }
  end
end
