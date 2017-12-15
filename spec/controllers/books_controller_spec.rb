RSpec.describe BooksController, type: :controller do
  describe "GET index" do
    it "renders the persisted data in both stores" do
      book = Book.new(id: "mybook", title: ["abc"], member_ids: [] )
      metadata_adapter = Valkyrie::MetadataAdapter.find(:composite_meta)
      book = metadata_adapter.save(resource: book)

      get :index
      expect(JSON.parse(response.body)["in_memory"][0]).to include("id" => "mybook", "title" => ["abc"])
      expect(JSON.parse(response.body)["in_postgres"][0]).to include("id" => "mybook", "title" => ["abc"])
    end
  end

  describe "GET show" do
    it "renders the saved object json" do
      book = Book.new(id: "mybook", title: ["abc"], member_ids: [] )
      metadata_adapter = Valkyrie::MetadataAdapter.find(:composite_meta)
      book = metadata_adapter.save(resource: book)

      get :show, params: { id: "mybook" }
      expect(JSON.parse(response.body)["in_memory"]).to include("id" => "mybook", "title" => ["abc"])
      expect(JSON.parse(response.body)["in_postgres"]).to include("id" => "mybook", "title" => ["abc"])
    end
  end

  describe "POST create" do
    it "renders the saved object json" do
      post :create, params: { id: "mybook", book: { title: ["abc"], member_ids: [] } }
      expect(JSON.parse(response.body)).to include("internal_resource" => "Book", "id" => "mybook", "title" => ["abc"])
    end
  end

  describe "PUT update" do
    it "renders the saved object json" do
      put :update, params: { id: "mybook", book: { title: ["abc"], member_ids: [] } }
      expect(JSON.parse(response.body)).to include("internal_resource" => "Book", "id" => "mybook", "title" => ["abc"])
    end
  end
end
