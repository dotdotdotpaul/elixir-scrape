defmodule ArticleTest do
  use ExUnit.Case

  test "article parser works" do
    html = sample_article "bbc"
    website = Scrape.Website.parse(html, "http://www.bbc.com/news/world-middle-east-34755443")
    data = Scrape.Article.parse(website, html)
    assert data.favicon == "http://static.bbci.co.uk/news/1.96.1453/apple-touch-icon.png"
    assert data.image == "http://ichef-1.bbci.co.uk/news/1024/cpsprodpb/3292/production/_86564921_86564920.jpg"
    assert data.title == "Russian plane crash: Too soon to know cause"
    assert data.url == "http://www.bbc.com/news/world-middle-east-34755443"
    assert length(data.tags) == 20
  end

  test "parser fails gracefully on worthless sites with bad structure" do
    html = sample_article "games-news"
    website = Scrape.Website.parse(html, "http://www.games-news.de/go/grim_dawn_an_krebs_verstorbener_fan_im_rollenspiel_verewigt/2194501/grim_dawn_an_krebs_verstorbener_fan_im_rollenspiel_verewigt.html?url=%2F")
    data = Scrape.Article.parse(website, html)
    assert data.url == "http://www.games-news.de/go/grim_dawn_an_krebs_verstorbener_fan_im_rollenspiel_verewigt/2194501/grim_dawn_an_krebs_verstorbener_fan_im_rollenspiel_verewigt.html?url=%2F"
    assert length(data.tags) == 7
  end

  test "parser doesn't retrieve content text from within markup by default" do
    html = sample_article "bbc"
    website = Scrape.Website.parse(html, "http://www.bbc.com/news/world-middle-east-34755443")
    data = Scrape.Article.parse(website, html)

    assert String.length(data.fulltext) > 0
    refute String.contains?(data.fulltext, "Sinai Province militants")

    # If we keep markup, it should be included...
    data = Scrape.Article.parse(website, html, keep_markup: true)
    assert String.length(data.fulltext) > 0
    assert String.contains?(data.fulltext, "Sinai Province militants</h2>")
  end

  test "parser accepts optional selector" do
    html = sample_article "bbc"
    website = Scrape.Website.parse(html, "http://www.bbc.com/news/world-middle-east-34755443")

    default_data = Scrape.Article.parse(website, html, keep_markup: true)
    assert String.length(default_data.fulltext) > 0
    assert String.contains?(default_data.fulltext, "Sinai Province militants</h2>")

    # Change the selector.
    data = Scrape.Article.parse(website, html, keep_markup: true, selector: "div.story-body__inner")
    assert String.length(data.fulltext) > 0
    refute data.fulltext == default_data.fulltext
    assert String.contains?(data.fulltext, "Sinai Province militants</h2>")
  end

  defp sample_article(name) do
    File.read! "test/sample_data/#{name}-article.html.eex"
  end
end
