# raintank_collector-cookbook

TODO: Enter the cookbook description here.

## Supported Platforms

TODO: List your supported platforms.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['raintank_collector']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### raintank_collector::default

Include `raintank_collector` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[raintank_collector::default]"
  ]
}
```

## License and Authors

Author:: Raintank, Inc. (<cookbooks@raintank.io>)
