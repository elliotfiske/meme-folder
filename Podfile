platform :ios, '10.0'
workspace 'memefolder.xcworkspace'

# Shared pods
pod 'RxSwift', '4.4.1'
pod 'RxCocoa', '4.4.1'

# Target-specific pods
target 'memefolder' do
    target 'YoutubeDL' do
        project 'YoutubeDL/YoutubeDL.xcodeproj'
        inherit! :search_paths
    end
end

target 'gifgrabber' do
end
