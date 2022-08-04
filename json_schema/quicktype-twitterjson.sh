npx quicktype --lang swift                              \
        -o TwitterAPIType.swift                         \
        --swift-5-support --no-initializers --all-properties-optional           \
        example_tweet.json example_tweet_images.json
