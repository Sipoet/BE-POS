class Asset::TemporarySaveService < ApplicationService

  def execute_service
    if params[:file].blank?
      render_json({message:'file cant read'},{status: :conflict})
      return
    end
    if params[:file].size > 2.megabytes
      render_json({message:'file is to big. max 2 MB'},{status: :conflict})
      return
    end
    filename = params[:file].name
    temp = Tempfile.new(['temp',filename])
    temp.write(params[:file].read)
    id = temp.path.split('/').last
    render_json({
      data:{
        id: id,
        type:'temporary_file'
      }
    }, {status: :created})
  end

end
