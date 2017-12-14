# frozen_string_literal: true
require 'valkyrie'
Rails.application.config.to_prepare do

  # Metadata Adapters
  postgres_meta = Valkyrie::Persistence::Postgres::MetadataAdapter.new
  Valkyrie::MetadataAdapter.register(
    postgres_meta,
    :postgres_meta
  )

  memory_meta = Valkyrie::Persistence::Memory::MetadataAdapter.new
  Valkyrie::MetadataAdapter.register(
    memory_meta,
    :memory_meta
  )

  # Metadata composite
  Valkyrie::MetadataAdapter.register(
    Valkyrie::Persistence::CompositePersister.new(memory_meta.persister, postgres_meta.persister),
    :composite_meta
  )

  # Storage Adapters
  disk_storage = Valkyrie::Storage::Disk.new(base_path: Rails.root.join("tmp", "files"))
  Valkyrie::StorageAdapter.register(
    disk_storage,
    :disk_storage
  )

  memory_storage = Valkyrie::Storage::Memory.new
  Valkyrie::StorageAdapter.register(
    memory_storage,
    :memory_storage
  )

  # Storage composite
  Valkyrie::MetadataAdapter.register(
    Valkyrie::Persistence::CompositePersister.new(disk_storage, memory_storage),
    :composite_storage
  )
end
