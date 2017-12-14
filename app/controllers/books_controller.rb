class BooksController < ApplicationController
  # curl --silent 'localhost:3000/books' | jq
  def index
    metadata_memory = Valkyrie::MetadataAdapter.find(:memory_meta)
    books_memory = metadata_memory.query_service.find_all_of_model(model: Book)

    metadata_postgres = Valkyrie::MetadataAdapter.find(:postgres_meta)
    books_postgres = metadata_postgres.query_service.find_all_of_model(model: Book)

    render json: { in_memory: resources_to_json(resources: books_memory), in_postgres: resources_to_json(resources: books_postgres) }
  end

  # curl --silent 'localhost:3000/books/5d54db6b-b521-4958-b5d6-fa88c0598184' | jq
  def show
    metadata_memory = Valkyrie::MetadataAdapter.find(:memory_meta)
    book_memory = metadata_memory.query_service.find_by(id: Valkyrie::ID.new(params[:id]))

    metadata_postgres = Valkyrie::MetadataAdapter.find(:postgres_meta)
    book_postgres = metadata_postgres.query_service.find_by(id: Valkyrie::ID.new(params[:id]))

    render json: { in_memory: resource_to_json(resource: book_memory), in_postgres: resource_to_json(resource: book_postgres) }
  end

  # curl --silent -X POST -H 'Content-Type: application/json' -d '{ "id": "5d54db6b-b521-4958-b5d6-fa88c0598184", "title": ["abc"], "member_ids": [] }' 'localhost:3000/books' | jq
  def create
    book = Book.new(persist_params)
    metadata_adapter = Valkyrie::MetadataAdapter.find(:composite_meta)
    book = metadata_adapter.save(resource: book)
    render json: resource_to_json(resource: book)
  end

  # curl --silent -X PUT -H 'Content-Type: application/json' -d '{ "title": ["xyz"], "member_ids": [] }' 'localhost:3000/books/5d54db6b-b521-4958-b5d6-fa88c0598184' | jq
  def update
    book = Book.new(persist_params)
    metadata_adapter = Valkyrie::MetadataAdapter.find(:composite_meta)
    book = metadata_adapter.save(resource: book)
    render json: resource_to_json(resource: book)
  end

  private

  def persist_params
    # Have to do to_hash.with_indifferent_access. Something breaks in the internals of dry-struct if not
    cleaned_params = permitted_params.to_hash.with_indifferent_access
    cleaned_params.merge({ id: Valkyrie::ID.new(params[:id]) }) if params.has_key?(:id)
  end

  def permitted_params
    params.require(:book).permit(:member_ids => [], :title => [])
  end

  def resource_to_json(resource:)
    # Have to do it this way atm, valkyrie id to_json will return a json containing { id: { id: "the id" } }
    resource.to_hash.merge({ id: resource.id.id })
  end

  def resources_to_json(resources:)
    # Have to do it this way atm, valkyrie id to_json will return a json containing { id: { id: "the id" } }
    resources.map do |r|
      resource_to_json(resource: r)
    end
  end
end
