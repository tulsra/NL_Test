
import Foundation

public enum Method: String {
    case capsules = "capsules"
    case launches = "launches"
    case launched_past = "launches/past"
}

enum NetworkEnvironment {
    case baseURL
    case production
    case serverURL
}

public enum NLApi {
    case recommended(page:Int)
    case req(method: Method,parameters:Parameters)
    case post(method: Method,parameters:Parameters)
    case postForJSON(method: Method,parameters:Parameters)
}

extension NLApi: EndPointType {
    
    var environmentBaseURL : String {
        switch NetworkManager.environment {
        case .production: return ""
        case .baseURL: return "https://api.spacexdata.com/v3/"
        case .serverURL: return ""
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .recommended(let id):
            return "\(id)/recommendations"
        case .req(let parm):
            return parm.method.rawValue
        case .post(let parm):
            return parm.method.rawValue
        case .postForJSON(let parm):
            return parm.method.rawValue
            
            
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .post( _):
            return .post
        case .postForJSON( _):
            return .post
        default:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
            
        case .req(let parameters):
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .urlEncoding,
                                      urlParameters: parameters.parameters)
        case .post(let parameters):
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .urlEncoding,
                                      urlParameters: parameters.parameters)
            
        case .postForJSON(let parameters):
            return .requestParameters(bodyParameters: parameters.parameters,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        default:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
