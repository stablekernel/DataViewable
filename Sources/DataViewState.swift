import Foundation

/// The empty data view state based on `isLoading` and `hasData`
///
/// - data: data view has data and is not loading
/// - loading: data view does not have data but is currently loading
/// - updating: data view has data and is currently loading
/// - empty: data view does not have data and is not loading
public enum DataViewState {
	case data
	case loading
	case updating
	case empty

	init(hasData: Bool, isLoading: Bool) {
		switch (hasData, isLoading) {
		case (true, true): self = .updating
		case (true, false): self = .data
		case (false, true): self = .loading
		case (false, false): self = .empty
		}
	}
}
