require 'spec_helper'

describe Locomotive::Liquid::Filters::Resize do

  before :each do
    @site             = Factory.create(:site)
    @theme_asset      = Factory.create(:theme_asset, :source => FixturedAsset.open('5k.png'), :site => @site)
    @theme_asset_path = "/sites/#{@theme_asset.site_id}/theme/images/5k.png"
    @asset            = Factory.create(:asset, :source => FixturedAsset.open('5k.png'), :site => @site)
    @asset_url        = @asset.source.url
    @asset_path       = "/sites/#{@asset.site_id}/assets/#{@asset.id}/5k.png"
    @context          = Liquid::Context.new( { }, { 'asset_url' => @asset_url, 'theme_asset' => @theme_asset.to_liquid }, { :site => @site })
    @app              = Locomotive::Dragonfly.app
  end

  describe '#resize' do

    context 'when an asset url string is given' do

      before :each do
        @template = Liquid::Template.parse('{{ asset_url | resize: "40x30" }}')
      end

      it 'should return the location of the resized image' do
        @template.render(@context).should =~ /images\/dynamic\/.*\/5k.png/
      end

      it 'should use the path in the public folder to generate a location' do
        @template.render(@context).should == @app.fetch_file("public#{@asset_path}").thumb('40x30').url
      end

    end

    context 'when a theme asset is given' do

      before :each do
        @template = Liquid::Template.parse("{{ theme_asset | resize: '300x400' }}")
      end

      it 'should return the location of the resized image' do
        @template.render(@context).should =~ /images\/dynamic\/.*\/5k.png/
      end

      it 'should use the path of the theme asset to generate a location' do
        @template.render(@context).should == @app.fetch_file("public#{@theme_asset_path}").thumb('300x400').url
      end

    end

    context 'when no resize string is given' do

      before :each do
        @template = Liquid::Template.parse('{{ asset | resize: }}')
      end

      it 'should return a liquid error' do
        @template.render(@context).should include 'Liquid error: wrong number of arguments'
      end

    end

  end

end