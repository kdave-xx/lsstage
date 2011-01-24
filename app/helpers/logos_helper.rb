module LogosHelper
  def include_lightbox
    stylesheet 'lightbox'
    
    javascript 'builder'
    javascript 'lightbox'
  end
  
  def artwork_for_form(f)
    if f.object.artwork
      f.object.artwork
    else
      Artwork.new
    end
  end
end
