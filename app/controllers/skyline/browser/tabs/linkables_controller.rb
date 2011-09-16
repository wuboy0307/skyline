class Skyline::Browser::Tabs::LinkablesController < Skyline::ApplicationController
  
  def show
    @linkable_type = Skyline::Linkable.linkables.find{|l| l.name == params[:id]}
    @linkables = @linkable_type.all
    @linkable = @linkable_type.find_by_id(params[:referable_id])
    
    render :update do |p|
    	p.replace_html("browserLinkableContentPanel", :partial => "show")
    end
  end
  
end