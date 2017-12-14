class BooksController < ApplicationController
  # curl 'localhost:3000/books'
  def index
    render json: { message: "index!" }
  end

  # curl 'localhost:3000/books/myid'
  def show
    metadata_memory = Valkyrie::MetadataAdapter.find(:memory_meta)
    book_memory = metadata_memory.query_service.find_by(id: Valkyrie::ID.new(params[:id]))

    #metadata_postgres = Valkyrie::MetadataAdapter.find(:postgres_meta)
    #book_postgres = metadata_postgres.query_service.find_by(id: Valkyrie::ID.new(params[:id]))

    render json: { in_memory: resource_to_json(resource: book_memory), in_postgres: {} }
  end

  # curl -X POST -H 'Content-Type: application/json' -d '{ "id": "myid", "title": ["abc"], "member_ids": [] }' 'localhost:3000/books'
  def create
    # Have to do to_hash.with_indifferent_access. Something breaks in the internals of dry-struct if not
    book = Book.new(permitted_params.to_hash.with_indifferent_access)
    metadata_adapter = Valkyrie::MetadataAdapter.find(:composite_meta)
    book = metadata_adapter.save(resource: book)
    render json: resource_to_json(resource: book)
  end

  # curl -X PUT -H 'Content-Type: application/json' -d '{ "title": ["xyz"], "member_ids": [] }' 'localhost:3000/books/myid'
  def update
    book = Book.new(permitted_params.to_hash.with_indifferent_access.merge({ id: params[:id] }))
    metadata_adapter = Valkyrie::MetadataAdapter.find(:composite_meta)
    book = metadata_adapter.save(resource: book)
    # Have to do it this way atm, valkyrie id to_json will return a json containing { id: { id: "the id" } }
    render json: book.to_hash.merge({ id: book.id.id })
  end

  private

  def permitted_params
    params.require(:book).permit(:member_ids => [], :title => [])
  end

  def resource_to_json(resource:)
    # Have to do it this way atm, valkyrie id to_json will return a json containing { id: { id: "the id" } }
    resource.to_hash.merge({ id: resource.id.id })
  end
end
