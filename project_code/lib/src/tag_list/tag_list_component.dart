import 'package:angular/angular.dart';
import '../../in_memory_data_service.dart';
import 'tag.dart';

@Component(
  selector: 'tag-list',
  styleUrls: const ['tag_list_component.css'],
  templateUrl: 'tag_list_component.html',
  directives: const [
    CORE_DIRECTIVES,
  ],
)

class TagListComponent implements OnInit {
  List<Tag> tagItems=[];

  void ngOnInit() {
    tagItems = InMemoryDataService.giveListOfTags();
  }
}